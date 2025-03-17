//*************************************************************************************************************************************
//@ Description : SDR Agent Function to update the Lead Status to 'SDR Qualified'
//@ Author      : Christoffel Smeets (ksmeets@salesforce.com)          
//@ Date        : 17 March 2025        
//@ Test Class  : S4S_SDR_Lead_QualifiedTest
//**************************************************************************************************************************************

public with sharing class S4S_SDR_Lead_Qualfied {
    
    @InvocableMethod
    public static List<Response> sdrLeadQualfied(List<Request> requests) {
        Request input = requests[0];
        List<Response> responses = new List<Response>();
        Response output = new Response();
        
        input.lead.Status = 'SDR Qualified';
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        input.lead.setOptions(dmo);

        Database.SaveResult sr = Database.update (input.lead);
        output.success =  sr.isSuccess();

        responses.add(output);
        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public Lead lead;
    }

    public class Response {
        @InvocableVariable
        public boolean success;
    }
}