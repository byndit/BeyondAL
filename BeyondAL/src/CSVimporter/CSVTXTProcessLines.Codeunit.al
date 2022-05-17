codeunit 50004 "BIT CSV TXT Process Lines"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Data Exch.";

    var
        DataTypeNotSupportedErr: Label 'The %1 column is mapped in the %2 format to a %3 field, which is not supported.', Comment = '%1=Field Value;%2=Field Value;%3=Filed Type';
        IncorrectFormatOrTypeErr: Label 'The file that you are trying to import, %1, is different from the specified %2, %3.\\The value in line %4, column %5 has incorrect format or type.\Expected format: %6, according to the %7 and %8 of the %9.\Actual value: "%10".', Comment = '%1=File Name;%2=Data Exch.Def Type;%3=Data Exch. Def Code;%4=Line No;%5=Column No;%6=Data Type;%7=Data Type Format;%8=Local;%9=Actual Value';
        MissingValueErr: Label 'The file that you are trying to import, %1, is different from the specified %2, %3.\\The value in line %4, column %5 is missing.', Comment = '%1=File Name;%2=Data Exch.Def Type;%3=Data Exch. Def Code;%4=Line No;%5=Column No';


    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        DataExchMapping: Record "Data Exch. Mapping";
        RecRef: RecordRef;
    begin
        DataExch.Get(Rec."Entry No.");

        DataExchMapping.setrange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchMapping.setrange("Data Exch. Line Def Code", DataExch."Data Exch. Line Def Code");
        DataExchMapping.FindFirst();

        RecRef.Open(DataExchMapping."Table ID");
        ProcessAllLinesColumnMapping(DataExch, RecRef);
        RecRef.Close();
    end;

    procedure ProcessAllLinesColumnMapping(DataExch: Record "Data Exch."; RecRef: RecordRef)
    var
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        if DataExchLineDef.FindSet then
            repeat
                ProcessColumnMapping(DataExch, DataExchLineDef, RecRef);
            until DataExchLineDef.Next() = 0;
    end;

    procedure ProcessColumnMapping(DataExch: Record "Data Exch."; DataExchLineDef: Record "Data Exch. Line Def"; RecRefTemplate: RecordRef)
    var
        DataExchField: Record "Data Exch. Field";
        DataExchFieldGroupByLineNo: Record "Data Exch. Field";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchMapping: Record "Data Exch. Mapping";
        TempFieldIdsToNegate: Record "Integer" temporary;
        RecRef: RecordRef;
        CurrLineNo: Integer;
        LastKeyFieldId: Integer;
        LineNoOffset: Integer;
    begin
        LastKeyFieldId := GetLastIntegerKeyField(RecRefTemplate);
        LineNoOffset := GetLastKeyValueInRange(RecRefTemplate, LastKeyFieldId);

        DataExchMapping.Get(DataExch."Data Exch. Def Code", DataExchLineDef.Code, RecRefTemplate.Number);

        DataExchFieldMapping.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchFieldMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        DataExchFieldMapping.SetRange("Table ID", RecRefTemplate.Number);
        DataExchFieldMapping.SetFilter(Priority, '<>%1', 0);
        if not DataExchFieldMapping.IsEmpty() then begin
            DataExchFieldMapping.SetCurrentKey("Data Exch. Def Code", "Data Exch. Line Def Code", "Table ID", Priority);
            DataExchFieldMapping.Ascending(false);
        end;
        DataExchFieldMapping.SetRange(Priority);

        DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        DataExchField.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);

        DataExchFieldGroupByLineNo.SetRange("Data Exch. No.", DataExch."Entry No.");
        DataExchFieldGroupByLineNo.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        DataExchFieldGroupByLineNo.Ascending(true);
        if not DataExchFieldGroupByLineNo.FindSet then
            exit;

        repeat
            if DataExchFieldGroupByLineNo."Line No." <> CurrLineNo then begin
                CurrLineNo := DataExchFieldGroupByLineNo."Line No.";
                RecRef := RecRefTemplate.Duplicate;
                if (DataExchMapping."Data Exch. No. Field ID" <> 0) and (DataExchMapping."Data Exch. Line Field ID" <> 0) then begin
                    SetFieldValue(RecRef, DataExchMapping."Data Exch. No. Field ID", DataExch."Entry No.");
                    SetFieldValue(RecRef, DataExchMapping."Data Exch. Line Field ID", CurrLineNo);
                end;
                SetFieldValue(RecRef, LastKeyFieldId, CurrLineNo * 10000 + LineNoOffset);
                DataExchFieldMapping.FindSet();
                repeat
                    DataExchField.SetRange("Line No.", CurrLineNo);
                    DataExchField.SetRange("Column No.", DataExchFieldMapping."Column No.");
                    if DataExchField.FindSet then
                        repeat
                            SetField(RecRef, DataExchFieldMapping, DataExchField, TempFieldIdsToNegate)
                        until DataExchField.Next() = 0
                    else
                        if not DataExchFieldMapping.Optional then
                            Error(
                              MissingValueErr, DataExch."File Name", GetType(DataExch."Data Exch. Def Code"),
                              DataExch."Data Exch. Def Code", CurrLineNo, DataExchFieldMapping."Column No.");
                until DataExchFieldMapping.Next() = 0;

                NegateAmounts(RecRef, TempFieldIdsToNegate);

                if RecRef.Insert() then;
            end;
        until DataExchFieldGroupByLineNo.Next() = 0;
    end;

    procedure SetField(RecRef: RecordRef; DataExchFieldMapping: Record "Data Exch. Field Mapping"; var DataExchField: Record "Data Exch. Field"; var TempFieldIdsToNegate: Record "Integer" temporary)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        TransformationRule: Record "Transformation Rule";
        TempBlob: Codeunit "Temp Blob";
        Fld: FieldRef;
        OutStr: OutStream;
        NegativeSignIdentifier: Text;
        TransformedValue: Text;
    begin
        DataExchColumnDef.Get(
          DataExchFieldMapping."Data Exch. Def Code",
          DataExchFieldMapping."Data Exch. Line Def Code",
          DataExchField."Column No.");

        Fld := RecRef.Field(DataExchFieldMapping."Field ID");

        TransformedValue := DataExchField.GetValue; // We shoud use the trim transformation rule instead of this
        if TransformationRule.Get(DataExchFieldMapping."Transformation Rule") then
            TransformedValue := TransformationRule.TransformText(DataExchField.Value);

        case Fld.Type of
            Fld.Type::Text,
            Fld.Type::Code:
                SetAndMergeTextCodeField(TransformedValue, Fld, DataExchFieldMapping."Overwrite Value");
            Fld.Type::Date:
                SetDateDecimalField(TransformedValue, DataExchField, Fld, DataExchColumnDef);
            Fld.Type::Decimal:
                if DataExchColumnDef."Negative-Sign Identifier" = '' then begin
                    SetDateDecimalField(TransformedValue, DataExchField, Fld, DataExchColumnDef);
                    AdjustDecimalWithMultiplier(Fld, DataExchFieldMapping.Multiplier, Fld.Value);
                end else begin
                    NegativeSignIdentifier := DataExchField.Value;
                    if UpperCase(DataExchColumnDef."Negative-Sign Identifier") = Uppercase(NegativeSignIdentifier) then
                        SaveNegativeSignForField(DataExchFieldMapping."Field ID", TempFieldIdsToNegate);
                end;
            Fld.Type::Option:
                SetOptionField(TransformedValue, Fld);
            Fld.Type::BLOB:
                begin
                    TempBlob.CreateOutStream(OutStr, TEXTENCODING::Windows);
                    OutStr.WriteText(TransformedValue);
                    TempBlob.ToRecordRef(RecRef, Fld.Number);
                end;
            else
                Error(DataTypeNotSupportedErr, DataExchColumnDef.Description, DataExchFieldMapping."Data Exch. Def Code", Fld.Type);
        end;
        if not DataExchFieldMapping."Overwrite Value" then
            Fld.Validate;
    end;

    local procedure SetOptionField(ValueText: Text; FieldRef: FieldRef)
    var
        OptionValue: Integer;
    begin
        while true do begin
            OptionValue += 1;
            if UpperCase(ValueText) = UpperCase(SelectStr(OptionValue, FieldRef.OptionCaption)) then begin
                FieldRef.Value := OptionValue - 1;
                exit;
            end;
        end;
    end;

    local procedure SetAndMergeTextCodeField(Value: Text; var FieldRef: FieldRef; OverwriteValue: Boolean)
    var
        CurrentLength: Integer;
    begin
        CurrentLength := StrLen(Format(FieldRef.Value));
        if (FieldRef.Length = CurrentLength) and not OverwriteValue then
            exit;
        if (CurrentLength = 0) or OverwriteValue then
            FieldRef.Value := CopyStr(Value, 1, FieldRef.Length)
        else
            FieldRef.Value := StrSubstNo('%1 %2', Format(FieldRef.Value), CopyStr(Value, 1, FieldRef.Length - CurrentLength - 1));
    end;

    local procedure SetDateDecimalField(ValueText: Text; var DataExchField: Record "Data Exch. Field"; var FieldRef: FieldRef; var DataExchColumnDef: Record "Data Exch. Column Def")
    var
        TypeHelper: Codeunit "Type Helper";
        Value: Variant;
    begin
        Value := FieldRef.Value;

        if not TypeHelper.Evaluate(
             Value, ValueText, DataExchColumnDef."Data Format", DataExchColumnDef."Data Formatting Culture")
        then
            Error(IncorrectFormatOrTypeErr,
              GetFileName(DataExchField."Data Exch. No."), GetType(DataExchColumnDef."Data Exch. Def Code"),
              DataExchColumnDef."Data Exch. Def Code", DataExchField."Line No.", DataExchField."Column No.", Format(FieldRef.Type),
              DataExchColumnDef.FieldCaption("Data Format"), DataExchColumnDef.FieldCaption("Data Formatting Culture"),
              DataExchColumnDef.TableCaption, DataExchField.Value);

        FieldRef.Value := Value;
    end;

    local procedure AdjustDecimalWithMultiplier(var FieldRef: FieldRef; Multiplier: Decimal; DecimalAsVariant: Variant)
    var
        DecimalValue: Decimal;
    begin
        DecimalValue := DecimalAsVariant;
        FieldRef.Value := Multiplier * DecimalValue;
    end;

    local procedure GetLastIntegerKeyField(RecRef: RecordRef): Integer
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRef := KeyRef.FieldIndex(KeyRef.FieldCount);
        if FieldRef.Type <> FieldType::Integer then
            exit(0);

        exit(FieldRef.Number);
    end;

    local procedure GetLastKeyValueInRange(RecRefTemplate: RecordRef; FieldId: Integer): Integer
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef := RecRefTemplate.Duplicate;
        SetKeyAsFilter(RecRef);
        FieldRef := RecRef.Field(FieldId);
        FieldRef.SetRange;
        if RecRef.FindLast then
            exit(RecRef.Field(FieldId).Value);
        exit(0);
    end;

    local procedure SetFieldValue(RecRef: RecordRef; FieldID: Integer; Value: Variant)
    var
        FieldRef: FieldRef;
    begin
        if FieldID = 0 then
            exit;
        FieldRef := RecRef.Field(FieldID);
        FieldRef.Validate(Value);
    end;

    local procedure SetKeyAsFilter(var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        i: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := RecRef.Field(KeyRef.FieldIndex(i).Number);
            FieldRef.SetRange(FieldRef.Value);
        end
    end;

    local procedure GetType(DataExchDefCode: Code[20]): Text
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.Get(DataExchDefCode);
        exit(Format(DataExchDef.Type));
    end;

    local procedure SaveNegativeSignForField(FieldId: Integer; var TempFieldIdsToNegate: Record "Integer" temporary)
    begin
        TempFieldIdsToNegate.Number := FieldId;
        TempFieldIdsToNegate.Insert();
    end;

    procedure NegateAmounts(RecRef: RecordRef; var TempFieldIdsToNegate: Record "Integer" temporary)
    var
        FieldRef: FieldRef;
        Amount: Decimal;
    begin
        if TempFieldIdsToNegate.FindSet then begin
            repeat
                FieldRef := RecRef.Field(TempFieldIdsToNegate.Number);
                Amount := FieldRef.Value;
                FieldRef.Value := -Amount;
                FieldRef.Validate;
            until TempFieldIdsToNegate.Next() = 0;
            TempFieldIdsToNegate.DeleteAll();
        end;
    end;

    local procedure GetFileName(DataExchEntryNo: Integer): Text
    var
        DataExch: Record "Data Exch.";
    begin
        DataExch.Get(DataExchEntryNo);
        exit(DataExch."File Name");
    end;
}
