@isTest
private class S4S_SDR_Lead_Data_BinderTest {

    @TestSetup static void testData() {  
        String[] keys = new String[]{'###HEADER###', 'Automotive','Aerospace'};
        List<S4S_Prompt_Binding__c> lpb = new List<S4S_Prompt_Binding__c>();

        for (string f: keys) {
            S4S_Prompt_Binding__c pb = new S4S_Prompt_Binding__c();
            pb.Name = 'Lead';
            pb.Field__c = 'Industry'; 
            pb.Key__c = f;
            pb.Value__c = 'TEST HEADER:';
            lpb.add(pb);
        }   
        insert lpb;

    }


@IsTest
    static void testGetPrompt() {

        User u = S4S_SDR_Lead_Data_BinderTest.createUser();
        
        List<PermissionSet> lps = [SELECT Id FROM PermissionSet WHERE Name IN ('S4S_SDR_Permission','EinsteinSdrAgent', 'S4S_SDR_Agent')];
        List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
        for (PermissionSet ps : lps) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            lpsa.add(psa);
        }
        insert lpsa; 

        Test.startTest();
       
        System.runAs(u) {


        RecordType leadRecordType = [select Id from RecordType where SobjectType = 'Lead' and DeveloperName = 'S4SInternal' limit 1];

        Lead l = new Lead (
            RecordTypeId = leadRecordType.Id, 
            Status = 'SDR Unqualified',           
            FirstName = 'John',
            S4SDivision__c  = 'IOT',
            Industry = 'Automotive',
            LastName = 'Doe' + String.valueOf(Math.random()).substring(2),             
            Company = 'Acme Corp',       
            Street = '123 Main St',        
            City = 'Sample City',         
            PostalCode = '90001',
            Country = 'DE',              
            Email = 'john.doe@example.com');
        insert l;

        List<S4S_SDR_Lead_Data_Binder.Request> requests = new List<S4S_SDR_Lead_Data_Binder.Request>();
        S4S_SDR_Lead_Data_Binder.Request request = new S4S_SDR_Lead_Data_Binder.Request();
        Lead lead = [SELECT Id From Lead limit 1];
        request.Recipient = lead;
        requests.add(request);

        //### Run the test
            List<S4S_SDR_Lead_Data_Binder.Response> responses = S4S_SDR_Lead_Data_Binder.getPrompt(requests);
            system.debug(responses[0].prompt);          
            Assert.isTrue(responses[0].prompt.startswith('TEST HEADER:'), 'Test header injected');
        }
        
        Test.stopTest();
        
        //### Check the results
        //response = responses[0];
        //System.assertEquals('This is a test Lead\nThis is a test Value', response.Prompt);
    }

    public static User createUser() {
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'test@test.com';
        u.Username = 'testuser' + String.valueOf(Math.random()).substring(2) + '@siemens.test';
        u.Alias = 'tuser';
        u.CommunityNickname = 'tuser';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name='Einstein Agent User'].Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
    
        return u;
    }
}