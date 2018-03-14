codeunit 50134 TestJson
{
    trigger OnRun()
    begin
        Json.Add('id',29562);
        Json.Add('status','done');
        JArray.Add(Json);
        JArray.WriteTo(str);
        Message(str);  
    end;
    
    var
        Json: JsonObject;
        JArray : JsonArray;   
        str : Text;
}