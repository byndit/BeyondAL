codeunit 50001 "BYD Web Request Mgt."
{
    procedure PerformWebRequest(Url: Text; Method: Enum "BYD Web Request Method"): HttpResponseMessage;
    var
        Content: HttpContent;
        RequestHeaders: Dictionary of [Text, Text];
    begin
        Content.WriteFrom('');
        exit(PerformWebRequest(Url, Method, RequestHeaders, Content));
    end;

    procedure PerformWebRequest(Url: Text; Method: Enum "BYD Web Request Method"; RequestHeaders: Dictionary of [Text, Text]): HttpResponseMessage;
    var
        Content: HttpContent;
    begin
        Content.WriteFrom('');
        exit(PerformWebRequest(Url, Method, RequestHeaders, Content));
    end;

    procedure PerformWebRequest(Url: Text; Method: Enum "BYD Web Request Method"; RequestHeaders: Dictionary of [Text, Text]; var Content: HttpContent): HttpResponseMessage;
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        HeaderKey: Text;
        HeaderValue: Text;
    begin
        foreach HeaderKey in RequestHeaders.Keys() do begin
            RequestHeaders.Get(HeaderKey, HeaderValue);
            Client.DefaultRequestHeaders.Add(HeaderKey, HeaderValue);
        end;

        case Method of
            Method::GET:
                Client.Get(Url, Response);
            Method::POST:
                Client.Post(Url, Content, Response);
            Method::PUT:
                Client.Put(Url, Content, Response);
            Method::DELETE:
                Client.Delete(Url, Response);
        end;
        exit(Response);
    end;

    procedure AddBasicAuthHeader(Username: Text; Password: Text; var RequestHeaders: Dictionary of [Text, Text])
    begin
        RequestHeaders.Add(AuthorizationTok, GetBasicAuthString(Username, Password));
    end;

    procedure AddBearerAuthHeader(Token: Text; var RequestHeaders: Dictionary of [Text, Text])
    begin
        RequestHeaders.Add(AuthorizationTok, StrSubstNo(BearerTok, Token));
    end;

    procedure ResponseAsJToken(Response: HttpResponseMessage): JsonToken
    var
        JToken: JsonToken;
        ResponseTxt: Text;
    begin
        Response.Content.ReadAs(ResponseTxt);
        JToken.ReadFrom(ResponseTxt);
        exit(JToken);
    end;

    procedure ResponseAsJObject(Response: HttpResponseMessage): JsonObject
    var
        JObject: JsonObject;
        ResponseTxt: Text;
    begin
        Response.Content.ReadAs(ResponseTxt);
        JObject.ReadFrom(ResponseTxt);
        exit(JObject);
    end;

    procedure ResponseAsJArray(Response: HttpResponseMessage): JsonArray
    var
        JArray: JsonArray;
        ResponseTxt: Text;
    begin
        Response.Content.ReadAs(ResponseTxt);
        JArray.ReadFrom(ResponseTxt);
        exit(JArray);
    end;

    procedure ResponseAsInStr(var InStr: InStream; Response: HttpResponseMessage)
    begin
        Response.Content.ReadAs(InStr);
    end;

    procedure ResponseAsXMLDoc(Response: HttpResponseMessage): XmlDocument
    var
        XmlDoc: XmlDocument;
        ResponseTxt: Text;
    begin
        Response.Content.ReadAs(ResponseTxt);
        XmlDocument.ReadFrom(ResponseTxt, XmlDoc);
        exit(XmlDoc);
    end;

    procedure ResponseAsTxt(Response: HttpResponseMessage): Text
    var
        ResponseTxt: Text;
    begin
        Response.Content.ReadAs(ResponseTxt);
        exit(ResponseTxt);
    end;

    procedure GetBasicAuthString(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(StrSubstNo(BasicAuthTok, Base64Convert.ToBase64(Username + ':' + Password)));
    end;

    procedure ISO8601ToDateTime(ISO8601Txt: Text): DateTime
    var
        DT: DateTime;
    begin
        Evaluate(DT, ISO8601Txt, 9);
        exit(DT);
    end;

    var
        BasicAuthTok: Label 'Basic %1', Locked = true;
        BearerTok: Label 'Bearer %1', locked = true;
        AuthorizationTok: Label 'Authorization', Locked = true;
}