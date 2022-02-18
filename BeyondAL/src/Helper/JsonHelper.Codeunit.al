codeunit 50000 "BYD Json Helper"
{
    procedure FindValue(JObject: JsonObject; Path: Text): JsonValue
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if JToken.IsValue() then
                exit(JToken.AsValue());
        Error(UnableToFindJsonValueErr, Path);
    end;

    procedure ValAsInt(JObject: JsonObject; Path: Text): Integer
    begin
        exit(FindValue(JObject, Path).AsInteger());
    end;

    procedure ValAsDec(JObject: JsonObject; Path: Text): Decimal
    begin
        exit(FindValue(JObject, Path).AsDecimal());
    end;

    procedure ValAsTxt(JObject: JsonObject; Path: Text): Text
    begin
        exit(FindValue(JObject, Path).AsText());
    end;

    procedure ValAsDT(JObject: JsonObject; Path: Text): DateTime
    begin
        exit(FindValue(JObject, Path).AsDateTime());
    end;

    procedure ValAsDate(JObject: JsonObject; Path: Text): Date
    begin
        exit(FindValue(JObject, Path).AsDate());
    end;

    procedure ValAsTime(JObject: JsonObject; Path: Text): Time
    begin
        exit(FindValue(JObject, Path).AsTime());
    end;

    procedure ValAsBool(JObject: JsonObject; Path: Text): Boolean
    begin
        exit(FindValue(JObject, Path).AsBoolean());
    end;

    procedure ValAsGuid(JObject: JsonObject; Path: Text): Guid
    var
        TempGuid: Guid;
    begin
        Evaluate(TempGuid, FindValue(JObject, Path).AsText());
        exit(TempGuid);
    end;

    procedure JObjectAsTxt(JObject: JsonObject): Text
    var
        JObjectText: Text;
    begin
        JObject.WriteTo(JObjectText);
        exit(JObjectText);
    end;

    procedure JArrayAsTxt(JArray: JsonArray): Text
    var
        JArrayText: Text;
    begin
        JArray.WriteTo(JArrayText);
        exit(JArrayText);
    end;

    procedure JObjectFromTxt(JObjectText: Text): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(JObjectText);
        exit(JObject);
    end;

    procedure JArrayFromTxt(JArrayText: Text): JsonArray
    var
        JArray: JsonArray;
    begin
        JArray.ReadFrom(JArrayText);
        exit(JArray);
    end;

    procedure ReadJArrayFromObj(JObject: JsonObject; Path: Text): JsonArray
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if JToken.IsArray() then
                exit(JToken.AsArray());
    end;

    procedure ReadJObjectFromObj(JObject: JsonObject; Path: Text): JsonObject
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Path, JToken) then
            if JToken.IsObject() then
                exit(JToken.AsObject());
    end;

    var
        UnableToFindJsonValueErr: Label 'Unable to find JSON value by path %1.', Comment = '%1 = Path';
}