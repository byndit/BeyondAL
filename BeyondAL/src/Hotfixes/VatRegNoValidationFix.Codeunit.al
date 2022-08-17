codeunit 50006 "BIT VAT Reg. No Validation Fix"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Lookup Ext. Data Hndl", 'OnSendRequestToVatRegistrationServiceOnBeforeSendRequestToWebService', '', false, false)]
    local procedure VATLookupExtDataHndlOnSendRequestToVatRegistrationServiceOnBeforeSendRequestToWebService(var SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt."; var TempBlobBody: Codeunit "Temp Blob")
    begin
        SOAPWebServiceRequestMgt.SetContentType('text/xml; charset=utf-8');
    end;
}