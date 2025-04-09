//*************************************************************************************************************************************
//@ Description : SDR Agent Function to update the Lead Status
//@ Author      : Christoffel Smeets (ksmeets@salesforce.com)          
//@ Date        : 17 March 2025        
//@ Test Class  : S4S_SDR_Lead_StatusTest
//**************************************************************************************************************************************


public with sharing class S4S_SDR_Lead_Status {
    private static Map<string,string> statusMap = new Map<string,string>{
        'CONTACTED'=>'Contacted',
        'RESPONDED'=>'Responded',
        'REJECTED'=>'Rejected',
        'LASTNUDGE'=>'LastNudge',
        'QUALIFIED'=>'Qualified'
    };
    private static List<String> proccesedStatus = new List<String>{'REJECTED', 'LASTNUDGE', 'QUALIFIED'};

    @InvocableMethod
    public static List<Response> updateLeadStatus(List<Request> requests) {
        Request input = requests[0];
        List<Response> responses = new List<Response>();
        Response output = new Response();

        String status = input.status.toUpperCase();
        status = status.trim();
        status = status.remove('.');

        if (statusMap.containsKey(status)) {
            input.lead.S4SSDR_Status__c = statusMap.get(status);
        }

        if (proccesedStatus.contains(status)) {
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            input.lead.setOptions(dmo);

            input.lead.S4SSDR_Processed__c = true;

        }
 
        Database.SaveResult sr = Database.update (input.lead);
        output.success =  sr.isSuccess();

        responses.add(output);
        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public Lead lead;
        @InvocableVariable(required=true)
        public string status;    
    }

    public class Response {
        @InvocableVariable
        public boolean success;
    }
}